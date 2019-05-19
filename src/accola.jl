"""
    accola_chars_r(e, g1, g2, g3)

Compute all characteristics of the form e+g, where g is in the group generated by g1, g2, g3.
"""
function accola_chars_r(e, g1, g2, g3)
    return [e, remainder_char(e+g1), remainder_char(e+g2), remainder_char(e+g3), remainder_char(e+g1+g2), remainder_char(e+g1+g3), remainder_char(e+g2+g3), remainder_char(e+g1+g2+g3)];
end

"""
    accola_chars_sr(chars, indices)

Compute the characteristics used in Accola's special theta relations.
"""
function accola_chars_sr(chars, indices)
    g1 = remainder_char(sum([chars[i] for i in indices[2]]));
    g2 = remainder_char(sum([chars[i] for i in indices[3]]));    
    g3 = remainder_char(sum([chars[i] for i in indices[4]]));
    return [accola_chars_r(chars[1], g1, g2, g3), accola_chars_r(chars[2], g1, g2, g3), accola_chars_r(chars[3], g1, g2, g3), accola_chars_r(chars[indices[1][4]], g1, g2, g3)];
end


"""
    accola_chars()

Compute all characteristics in the 8 Accola special theta relations, for a fixed fundamental system.
"""
function accola_chars()
    chars = [[[1,0,0,0,0],[0,0,0,0,0]],
             [[0,1,0,0,0],[1,0,0,0,0]],
             [[0,0,1,0,0],[1,1,0,0,0]],
             [[0,0,0,1,0],[1,1,1,0,0]],
             [[0,0,0,0,1],[1,1,1,1,0]],
             [[1,0,0,0,0],[0,1,1,1,1]],
             [[0,1,0,0,0],[0,0,1,1,1]],
             [[0,0,1,0,0],[0,0,0,1,1]],
             [[0,0,0,1,0],[0,0,0,0,1]],
             [[1,1,1,1,0],[0,1,0,1,0]],
             [[1,1,1,1,0],[1,0,1,0,1]]];
    chars_sr_indices = [[[1,2,3,4], [5,6,7,8], [5,6,9,10], [5,7,9,11]], #SR1234
                        [[1,2,3,5], [4,6,7,8], [4,6,9,10], [4,7,9,11]], #SR1235
                        [[1,2,3,6], [5,4,7,8], [5,4,9,10], [5,7,9,11]], #SR1236
                        [[1,2,3,7], [5,6,4,8], [5,6,9,10], [5,4,9,11]], #SR1237
                        [[1,2,3,8], [5,6,7,4], [5,6,9,10], [5,7,9,11]], #SR1238
                        [[1,2,3,9], [5,6,7,8], [5,6,4,10], [5,7,4,11]], #SR1239
                        [[1,2,3,10], [5,6,7,8], [5,6,9,4], [5,7,9,11]], #SR12310
                        [[1,2,3,11], [5,6,7,8], [5,6,9,10], [5,7,9,4]]]; #SR12311
    return [accola_chars_sr(chars, i) for i in chars_sr_indices];
end


"""
    accola(τ, chars=accola_chars())

Compute the 8 Accola special theta relations, without taking the product over the signs of the square roots. Return the largest absolute value of the special theta relation.
"""
function accola(τ::Array{<:Number}, chars=accola_chars())
    R = RiemannMatrix(τ);
    return accola(R, chars);
end


"""
    accola(R, chars=accola_chars())

Compute the 8 Accola special theta relations, without taking the product over the signs of the square roots. Return the largest absolute value of the special theta relation.
"""
function accola(R::RiemannMatrix, chars=accola_chars())
    z = zeros(5);
    theta_constants = [[[theta(z, R, char=c) for c in chars_r] for chars_r in chars_sr] for chars_sr in chars];
    accola_r = [[sqrt(prod(theta_constant)) for theta_constant in theta_r] for theta_r in theta_constants];
    accola_sr = [[r[1] + r[2] + r[3] + r[4],
                  r[1] + r[2] + r[3] - r[4],
                  r[1] + r[2] - r[3] + r[4],
                  r[1] + r[2] - r[3] - r[4],
                  r[1] - r[2] + r[3] + r[4],
                  r[1] - r[2] + r[3] - r[4],
                  r[1] - r[2] - r[3] + r[4],
                  r[1] - r[2] - r[3] - r[4]]
                 for r in accola_r];
    max_accola_sr = maximum([minimum(abs.(sr)) for sr in accola_sr]);
    return max_accola_sr;
end

"""
    random_nonaccola(tol=0.1, trials=100)

Find a random genus 5 matrix in the Siegel upper half space which is not in the Accola locus, such that the largest Accola relation has absolute value at least tol, using input number of trials.
"""
function random_nonaccola(tol::Real=0.1, trials::Integer=100)
    chars = accola_chars();
    t = 0; # stores value of largest Accola relation encountered
    i = 0; # counter for number of trials
    max_matrix = rand(5,5); # stores candidate matrix
    while t < tol && i < trials
        τ = random_siegel(5);
        s = accola(τ, chars);
        if s > t
            t = s;
            max_matrix = τ;
        end
        i += 1;
    end
    return [max_matrix, t];
end